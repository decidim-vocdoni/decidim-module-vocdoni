import { Election, PlainCensus } from "@vocdoni/sdk";
import { initVocdoniClient } from "./init_vocdoni_client";

/*
 * Creates an Election in the Vocdoni API
 * Instantiates the Vocdoni SDK client using the Wallet's private key given as parameter.
 * Based on the TypeScript example provided in the GitHub repository.
 *
 * @param {object} options All the different options that interact with setting up an Election.
 * @property {string} options.graphqlApiUrl The URL for the GraphQL API where to extract the Election metadata
 * @property {number|string} options.componentId The ID of the Vocdoni Component in Decidim
 * @property {number|string} options.electionId The ID of the Vocdoni Election in Decidim
 * @param {function} onSuccess A callback function to be run when the Election is successfully sent to the API
 * @param {function} onFailure A callback function to be run when the Election sent to the API has a failure
 *
 * @see {@link https://developer.vocdoni.io|Documentation}
 * @see {@link https://github.com/vocdoni/vocdoni-sdk/blob/ad03822f537fd8c4d43c85d447475fd38b62909c/examples/typescript/src/index.ts|TypeScript example}
 */
export default class CreateVocdoniElection {
  constructor(options = {}, onSuccess, onFailure) {
    this.graphqlApiUrl = options.graphqlApiUrl;
    this.componentId = options.componentId;
    this.electionId = options.electionId;
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.client = null;

    console.group("Options");
    console.log("GRAPHQL API URL => ", options.graphqlApiUrl);
    console.log("VOCDONI COMPONENT ID => ", options.componentId);
    console.log("ELECTION ID => ", options.electionId);
    console.groupEnd();
  }

  /*
   * Listens to the "Create election in Vocdoni API" button and runs the methods when they're clicked.
   *
   * @returns {void}
   */
  run() {
    this._setVocdoniClient();
    this._createElection();
  }

  /*
   * Gets the wallet and initialize the Vocdoni SDK Client with it
   * Binds the client to the instance
   *
   * @returns {void}
   */
  async _setVocdoniClient() {
    this.client = initVocdoniClient();

    const clientInfo = await this.client.createAccount();
    if (clientInfo.balance === 0) {
      await this.client.collectFaucetTokens();
    }

    console.log("CLIENT => ", this.client);
  }

  /*
   * Create the demo election in Vocdoni API.
   *
   * @returns {void}
   */
  async _createElection() {
    let result = null;

    try {
      const election = await this._initializeElection();
      console.log("ELECTION => ", election);

      const vocdoniElectionId = await this.client.createElection(election);
      result = `OK! VOCDONI ELECTION ID => ${vocdoniElectionId}`;
      this.onSuccess(vocdoniElectionId);
    } catch (error) {
      result = `ERROR! ${error}`;
      this.onFailure();
    }

    console.log("RESULT => ", result);
  }

  /*
   * Parses the election metadata and instantiates an Election object using Vocdoni SDK
   * This metadata and configuration are fetch with the Decidim GraphQL API using the demo-graphql app
   *
   * @param {string} defaultLocale Optional. A string with the value of the default locale (for instance "en")
   *    Required by Vocdoni.
   *
   * @returns {object} election The election object with the metadata
   */
  async _initializeElection(defaultLocale = "en") {

    /*
     * Transform the locales to the required format with a default locale
     *
     * @param {array} array An array with the following format:
     *    [{"text": "Nom", "locale": "ca"}, {"text": "Name","locale": "en"}]
     *
     * @returns {object} An object with the following format:
     *    {ca: "Nom", default: "Name"}
     */
    const transformLocales = (array) => {
      return array.reduce((obj, elem) => {
        let localeName = elem.locale;
        if (elem.locale === defaultLocale) {
          localeName = "default";
        }

        obj[localeName] = elem.text;
        return obj;
      }, {});
    }

    let electionMetadata = await this._getElectionMetadata();
    electionMetadata = electionMetadata.data.component.election;
    let header = electionMetadata.attachments[0].url;
    if (!header.startsWith("http")) {
      header = `${window.location.origin}${header}`
    }

    const walletsAddresses = electionMetadata.voters.map((voter) => voter.wallet_address);
    const census = this._initializeCensus(walletsAddresses);

    const election = Election.from({
      title: transformLocales(electionMetadata.title.translations, defaultLocale),
      description: transformLocales(electionMetadata.description.translations, defaultLocale),
      header: header,
      streamUri: electionMetadata.streamUri,
      startDate: Date.parse(electionMetadata.startTime),
      endDate: Date.parse(electionMetadata.endTime),
      census,
      electionType: {
        secretUntilTheEnd: electionMetadata.secretUntilTheEnd
      }
    });

    electionMetadata.questions.forEach((question) => {
      election.addQuestion(
        transformLocales(question.title.translations, defaultLocale),
        transformLocales(question.description.translations, defaultLocale),
        question.answers.map((answer) => {
          return {
            title: transformLocales(answer.title.translations, defaultLocale),
            value: Number(answer.id)
          }
        })
      );
    })

    return election;
  }

  /*
   * Gets the election Metadata from the Decidim GraphQL API
   *
   * @returns {Promise<object>} data The promise of the response in JSON format
   */
  async _getElectionMetadata() {
    const query = `
      query getElectionMetadata($componentId: ID!, $electionId: ID!) {
        component(id: $componentId) {
          id
          name { translations { text locale } }
          ... on VocdoniElections {
            name { translations { text locale } }
            election(id: $electionId) {
                status
                id
                title { translations { text locale } }
                description { translations { text locale } }
                attachments { thumbnail url type }
                streamUri
                startTime
                endTime
                secretUntilTheEnd
                voters {
                  wallet_address
                }
                questions {
                  title { translations { text locale } }
                  description { translations { text locale } }
                  answers {
                    id
                    title { translations { text locale } }
                  }
                }
              }
          }
        }
      }
    `
    const componentId = Number(this.componentId);
    const electionId = Number(this.electionId);

    return new Promise((resolve) => {
      fetch(this.graphqlApiUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: JSON.stringify({
          query,
          variables: {
            componentId,
            electionId
          }
        })
      }).
        then((response) => response.json()).
        then((data) => resolve(data));
    });
  }

  /*
   * Initializes a Census object
   *
   * @param {string[]} voters An array with all the wallets public keys
   *
   * @returns {<object>} census The PlainCensus object initialized with all the wallets public keys
   */
  _initializeCensus(voters) {
    const census = new PlainCensus();
    for (const voter of voters) {
      census.add(voter);
    }
    return census;
  }
}
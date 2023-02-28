import { VocdoniSDKClient } from "@vocdoni/sdk";

/*
 * Instantiate the Wallet object given a login form with the email and the date of birth
 * of the potenital voter
 *
 * @param {object} $loginForm The jQuery Element with the form for logging in
 *
 * @returns {object} the Wallet object generated or an empty object
 */
export const walletFromLoginForm = ($loginForm) => {
  if ($loginForm === null) {
    return {};
  }

  const email = $loginForm.find("#login_email").val();
  let bornAtDay = $loginForm.find("#login_day").val();
  let bornAtMonth = $loginForm.find("#login_month").val();
  const bornAtYear = $loginForm.find("#login_year").val();

  if (!email.includes("@")) {
    return {};
  }

  if (bornAtYear.length !== 4) {
    return {};
  }

  if (bornAtDay.length === 1) {
    bornAtDay = `0${bornAtDay}`;
  }

  if (bornAtMonth.length === 1) {
    bornAtMonth = `0${bornAtMonth}`;
  }

  const bornAt = `${bornAtYear}-${bornAtMonth}-${bornAtDay}`;

  console.group("Wallet data");
  console.log("EMAIL => ", email);
  console.log("BORN AT => ", bornAt);
  console.groupEnd();

  for (const value of [email, bornAtDay, bornAtMonth, bornAtYear]) {
    if (value === "") {
      return {};
    }
  }

  const userWallet = VocdoniSDKClient.generateWalletFromData([email, bornAt]);

  return userWallet;
}

export const checkIfWalletIsInCensus = async (env, wallet, electionId) => {
  const client = new VocdoniSDKClient({ env, wallet })
  client.setElectionId(electionId);
  const isInCensus = await client.isInCensus();
  return isInCensus;
}

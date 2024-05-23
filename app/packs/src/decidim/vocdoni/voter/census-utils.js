import { VocdoniSDKClient } from "@vocdoni/sdk";

/*
 * Instantiate the Wallet object given a login form with the email and the token
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

  const email = $loginForm.find("#login_email").val().toLowerCase();
  const token = $loginForm.find("#login_token").val().toLowerCase();

  if (!email.includes("@")) {
    return {};
  }

  console.group("Wallet data");
  console.log("EMAIL => ", email);
  console.log("TOKEN => ", token);
  console.groupEnd();

  for (const value of [email, token]) {
    if (value === "") {
      return {};
    }
  }

  const userWallet = VocdoniSDKClient.generateWalletFromData([email, token]);

  return userWallet;
}

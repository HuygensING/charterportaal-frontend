let baseUrl = "https://test.repository.huygens.knaw.nl/v2.1";

export default {
	baseUrl: baseUrl,
	federatedAuthenticateUrl: "https://secure.huygens.knaw.nl/saml2/login",
	basicAuthenticateUrl: baseUrl + "/authenticate",
	userUrl: baseUrl + "/system/users/me"
};
import React from "react";
import appRouter from "./router";
import App from "./components/app";

const ROOT = "/charterportaal";

React.render(<App />, document.querySelector(".app"));


appRouter.history.start({
	root: ROOT
});



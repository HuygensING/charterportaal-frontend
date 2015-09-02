import React from "react";
import appRouter from "./router";
import App from "./components/app";

const ROOT = "/charterportaal";

appRouter.history.start({
	root: ROOT
});

React.render(<App />, document.querySelector(".app"));

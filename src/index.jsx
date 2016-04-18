import React from "react";
import appRouter from "./router";
import App from "./components/app";
import {fetchRelationTypes} from "./actions/relation-types";

const ROOT = "/charterportaal";

React.render(<App />, document.querySelector(".app"));


fetchRelationTypes(function() {
	appRouter.history.start({
		root: ROOT
	});
});

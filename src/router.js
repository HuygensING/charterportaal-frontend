import Router from "ampersand-router";
import React from "react";
import Search from "./components/search";


let AppRouter = Router.extend({
	routes: {
		'': 'search',
	},

	search: function() {
		React.render(<Search />, document.querySelector(".search"));
	},
});

export default new AppRouter();

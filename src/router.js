import Router from "ampersand-router";
import React from "react";
import Search from "./components/search";
import {selectEntry} from "./actions/entry";
import appStore from "./app-store";

let showPage = function(page) {
	[".search", ".edit-entry"].forEach((pageClass) =>
		document.querySelector(pageClass).style.display = (page === pageClass) ? "block" : "none"
	);
};

let AppRouter = Router.extend({
	routes: {
		'': 'search',
		'search': 'search',
		"entry/:id": 'entry'
	},

	search: function() {
		showPage(".search");
	},

	entry: function(id) {
		if(appStore.getState().entry.data === null) {
			appStore.dispatch(selectEntry({id : id}));
		}
		console.log("HELLo?")
		showPage(".edit-entry");
	}

});

export default new AppRouter();

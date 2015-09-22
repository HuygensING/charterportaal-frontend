import Router from "ampersand-router";
import React from "react";
import Search from "./components/search";

let showPage = function(page) {
	[".search", ".edit"].forEach((pageClass) =>
		document.querySelector(pageClass).style.display = (page === pageClass) ? "block" : "none"
	);
};

let AppRouter = Router.extend({
	routes: {
		'': 'search',
		'search': 'search',
		":id/edit": 'edit'
	},

	search: function() {
		showPage(".search");
	},

	edit: function(id) {
		showPage(".edit");
	}

});

export default new AppRouter();

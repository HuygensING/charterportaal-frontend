import React from "react";
import FacetedSearch from "hire-faceted-search";
import Result from "./result";

const labels = {
	facetTitles: {
		"dynamic_s_creator": "Auteur",
		"dynamic_sort_creator": "Auteur",
		"dynamic_sort_title": "Titel",
		"dynamic_s_origin": "Land",
		"dynamic_s_genre": "Genre",
		"dynamic_s_language": "Taal",
		"createdBy": "Auteur",
		"language": "Taal",
		"date": "Datum"
	},
	"resultsFound": "resultaten",
	"sortBy": "Sorteer op",
	"showAll": "Alles",
	"newSearch": "Nieuwe zoekvraag"
};


class Search extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			childIsOpen: false
		}

		this.renderedSearch = null;
	}

	onSelect(data) {
		if(document.querySelector(".more-info-opened")) {
			this.setState({childIsOpen: true});
		} else {
			this.setState({childIsOpen: false});
		}
	}

	onChange(results, query) {
		this.setState({childIsOpen: false});
	}

	renderSearch() {
		this.renderedSearch = this.renderedSearch || 
			<FacetedSearch
					config={{
						baseURL: "/repository/api/v2.1",
						searchPath: "/search/wwdocuments",
						levels: ["dynamic_sort_creator", "dynamic_sort_title"],
						headers: {VRE_ID: "WomenWriters", Accept: "application/json"}
					}}
					facetList={[
						"dynamic_s_creator",
						"dynamic_s_origin",
						"dynamic_s_language",
						"dynamic_s_genre"
					]}
					labels={labels}
					metadataList={[
						"createdBy",
						"publishLocation",
						"language",
						"date"
					]}
					onChange={this.onChange.bind(this)}
					onSelect={this.onSelect.bind(this)}
					resultComponent={Result}
					/>;
		return this.renderedSearch;
	}

	render() {
		return (
			<div className={this.state.childIsOpen ? "child-is-open" : null}>
				{this.renderSearch()}
			</div>
		);
	}


}

export default Search;
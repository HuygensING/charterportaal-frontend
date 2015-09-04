import React from "react";
import FacetedSearch from "hire-faceted-search";
import Result from "./result";

const labels = {
	facetTitles: {
		"dynamic_sort_creator": "Auteur",
		"dynamic_sort_title": "Titel",
		"dynamic_i_date": "Datum"
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
/*						baseURL: "/repository/api/v2.1",*/
						baseURL: "https://test.repository.huygens.knaw.nl/v2.1",
						searchPath: "/search/charterdocuments",
						levels: ["dynamic_sort_creator", "dynamic_sort_title"],
						headers: {VRE_ID: "Charter", Accept: "application/json"}
					}}
					facetList={["dynamic_i_date"]}
					labels={labels}
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
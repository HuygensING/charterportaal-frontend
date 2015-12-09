import React from "react";
import FacetedSearch from "hire-faceted-search";
import Result from "./result";
import config from "../config";

const labels = {
	facetTitles: {
		"dynamic_i_date": "Datum",
		"dynamic_s_archief": "Archief",
		"dynamic_s_document_type": "Documenttype",
		"dynamic_s_fonds": "Fonds",
		"dynamic_s_editions": "Uitgaves",
		"term": "Titel"
	},
	"dynamic_sort_creator": "Oorkonder",
	"dynamic_sort_title": "Titel",
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
		if(data && data.editThisRecord) {
			this.props.onViewClick(data);
		} else {
			if(document.querySelector(".more-info-opened")) {
				this.setState({childIsOpen: true});
			} else {
				this.setState({childIsOpen: false});
			}
		}
	}

	onChange(results, query) {
		this.setState({childIsOpen: false});
	}

	renderSearch() {
		this.renderedSearch = this.renderedSearch || 
			<FacetedSearch
					config={{
						baseURL: config.baseUrl,
						searchPath: "/search/charterdocuments",
						headers: {VRE_ID: "Charter", Accept: "application/json"}
					}}
					labels={labels}
					onChange={this.onChange.bind(this)}
					onSelect={this.onSelect.bind(this)}
					customComponents={{result: Result}}
					/>;
		return this.renderedSearch;
	}

	render() {
		return (
			<div className={(this.state.childIsOpen ? "child-is-open " : null) }>
				{this.renderSearch()}
			</div>
		);
	}


}

Search.propTypes = {
	user: React.PropTypes.object,
	onViewClick: React.PropTypes.func.isRequired
}

export default Search;
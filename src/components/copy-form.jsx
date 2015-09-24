import React from "react";
import form from "hire-forms-form";
import Autocomplete from "hire-forms-autocomplete";
import {getDocumentSuggest} from "../api";

const INIT_STATE = {relation: {key: "isCopyOf", value: ""}};

class CopyForm extends React.Component {
	constructor(props) {
		super(props);

		this.state = INIT_STATE;
	}

	componentWillReceiveProps (nextProps) {
		console.log("componentWillReceiveProps", nextProps.id, this.props.id);
		if(nextProps.id !== this.props.id) {
			this.setState(INIT_STATE);
  		}
	}


	handleChange(value) {
		this.setState({relation: value});
	}

	handleSubmit() {
		this.setState(INIT_STATE);
		this.props.onChange(this.state);
	}

	render() {
		return (
			<div>
				<div className="autocomplete-wrapper">
					<Autocomplete
						async={getDocumentSuggest}
						onChange={this.handleChange.bind(this)}
						value={this.state.relation} />
				</div>
				<button className="autocomplete-button" onClick={this.handleSubmit.bind(this)} style={{verticalAlign: "top"}}>Toevoegen</button>
			</div>
		);
	}
}

CopyForm.propTypes = {
	id: React.PropTypes.string,
	onChange: React.PropTypes.func.isRequired
};

export default form(CopyForm);
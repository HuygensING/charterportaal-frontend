import React from "react";
import ExternalIcon from "./icons/external";

class Result extends React.Component {
	onViewClick(data) {
		this.props.onSelect({...data, editThisRecord: true});
	}

	render() {
		return (
			<li onClick={this.onViewClick.bind(this, this.props.data)}>
				<label>{this.props.data.displayName.split(" ").slice(1).join(" ")}</label>
				<span className="result-date">
					{this.props.data.data.date}
				</span>
			</li>
		)
	}
}

Result.propTypes = {
	data: React.PropTypes.object,
	onSelect: React.PropTypes.func.isRequired
}

export default Result;
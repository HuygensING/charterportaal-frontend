import React from "react";


class Edit extends React.Component {
	constructor(props) {
		super(props);
	}

	renderBody() {
		console.log(this.props.data);
		if(!this.props.user.token) { return (<div>unauthorized</div>); } 
		return (
			<div>
				<h2>{this.props.data.title}</h2>
			</div>
		)
	}

	render() {
		let body = this.renderBody();
		return (
			<div>
				<a className="button" onClick={this.props.onBackClick} >Terug</a>
				{body}
			</div>
		)
	}
}

Edit.propTypes = {
	data: React.PropTypes.object,
	onBackClick: React.PropTypes.func.isRequired,
	user: React.PropTypes.object
};

export default Edit;
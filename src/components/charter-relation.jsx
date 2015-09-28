import React from "react"


class CharterRelation extends React.Component {

	handleClick() {
		this.props.onClick({id: this.props.data.id});
	}

	handleDeleteClick() {
		this.props.onDelete(this.props.type, this.props.data);
	}

	render() {
		let deleteButton = (this.props.user && this.props.user.token) ?
			<button onClick={this.handleDeleteClick.bind(this)} >Verwijderen</button> : null;

		return (
			<li>
				{deleteButton}
				<a onClick={this.handleClick.bind(this)}>
					{this.props.data.displayName}
				</a>
			</li>
		)
	}
}

CharterRelation.propTypes = {
	data: React.PropTypes.object.isRequired,
	onClick: React.PropTypes.func.isRequired,
	onDelete: React.PropTypes.func.isRequired,
	type: React.PropTypes.string.isRequired,
	user: React.PropTypes.object
};

export default CharterRelation;

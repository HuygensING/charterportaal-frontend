import React from "react";
import CopyForm from "./copy-form";
import {addIsCopyOfRelation} from "../actions/entry";
import appStore from "../app-store";

class Edit extends React.Component {
	constructor(props) {
		super(props);
	}

	addCopyOf(obj) {
		let targetId = obj.relation.key.replace(/^.*\//, "");
		appStore.dispatch(addIsCopyOfRelation(this.props.data._id, targetId, this.props.user.token));
	}

	renderBody() {
		if(!this.props.user.token) { return (<div>unauthorized</div>); } 
		if(!this.props.data.title) { return (<div></div>); }

		let link = this.props.data.links.length > 0 ? 
			(<li><label>Link</label><a href={this.props.data.links[0].url} target="_blank">{this.props.data.links[0].url}</a></li>) : null;


		return (
			<div>
				<h2>{this.props.data.title}</h2>
				<ul>
					<li>
						<label>Datum</label>
						{this.props.data.date}
					</li>
					{link}
					<li>
						<label>Inventaristekst</label>
						{this.props.data.inventaristekst.join("; ")}
					</li>
					<li>
						<label>Is kopie van</label>
						<CopyForm id={this.props.data._id} onChange={this.addCopyOf.bind(this)} />
					</li>
				</ul>
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
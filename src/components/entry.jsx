import React from "react";
import CopyForm from "./copy-form";
import {addIsCopyOfRelation} from "../actions/entry";
import ExternalIcon from "./icons/external";
import appStore from "../app-store";

class Entry extends React.Component {
	constructor(props) {
		super(props);
	}

	addCopyOf(obj) {
		let targetId = obj.relation.key.replace(/^.*\//, "");
		if(targetId !== "isCopyOf") {
			appStore.dispatch(addIsCopyOfRelation(this.props.data._id, targetId, this.props.user.token));
		}
	}

	renderBody() {
		if(!this.props.data.title) { return (<div></div>); }
		
		let form = this.props.user.token ?
			(<CopyForm id={this.props.data._id} onChange={this.addCopyOf.bind(this)} />)
			: null;

		let link = this.props.data.links.length > 0 ? 
			(<li>
				<label>Link</label>
				<a href={this.props.data.links[0].url} target="_blank">Archief <ExternalIcon /></a>
			</li>) : null;


		return (
			<div className="entry">
				<h2>{this.props.data.title}</h2>
				<ul>
					<li>
						<label>Datum</label>
						{this.props.data.date}
					</li>
					{link}
					<li>
						<label>Inventaristekst</label>
						{this.props.data.inventaristekst.map((txt) => (<p>{txt}</p>) )}
					</li>
					<li>
						<label>Is kopie van</label>
						{form}
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

Entry.propTypes = {
	data: React.PropTypes.object,
	onBackClick: React.PropTypes.func.isRequired,
	user: React.PropTypes.object
};

export default Entry;
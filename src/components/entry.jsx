import React from "react";
import CopyForm from "./copy-form";
import {addRelation, removeRelation} from "../actions/entry";
import ExternalIcon from "./icons/external";
import appStore from "../app-store";
import CharterRelation from "./charter-relation";
import config from "../config";


class Entry extends React.Component {
	constructor(props) {
		super(props);
	}

	addRelation(type, obj) {
		if(obj.relation.value.length === 0) { return; }
		let targetId = obj.relation.key.replace(/^.*\//, "");
		appStore.dispatch(addRelation(this.props.data._id, type, targetId, this.props.user.token));
	}

	removeRelation(type, relation) {
		appStore.dispatch(removeRelation(this.props.data._id, type, relation, this.props.user.token));
	}

	renderRelations(type, entryForm) {
		let relations = (this.props.data["@relations"][type] || []).filter((rel) => rel.accepted);
		if (relations.length || entryForm) {
			return (
				<li>
					<label>{type === "isCopyOf" ? "Is kopie van" : "Wordt gekopiëerd door"}</label>
					{relations.length ? <ul>
						{relations.map((relation, i) =>
							<CharterRelation
								data={relation}
								key={i}
								onClick={this.props.onChange.bind(this)}
								onDelete={this.removeRelation.bind(this)}
								type={type}
								user={this.props.user} />
						)}
					</ul> : null}
					{entryForm}
				</li>
			)
		} else {
			return null;
		}
	}

	renderBody() {
		if(!this.props.data.title) { return (<div></div>); }

		let form = this.props.user.token ?
			(<CopyForm id={this.props.data._id} onChange={this.addRelation.bind(this, "isCopyOf")} />)
			: null;

		let inverseForm = this.props.user.token ?
			(<CopyForm id={this.props.data._id} onChange={this.addRelation.bind(this, "isCopiedBy")} />)
			: null;

		let link = this.props.data.links.length > 0 ?
			(<li>
				<label>Link</label>
				<a href={this.props.data.links[0].url} target="_blank">Archief <ExternalIcon /></a>
			</li>) : null;
		let regest = (this.props.data.regestNummer || (this.props.data.tekstRegest && this.props.data.tekstRegest.length)) ?
			(<li>
				<label>Regest</label>
				Nummer: {this.props.data.regestNummer || ""}
				{this.props.data.tekstRegest.map((txt, i) => (<p key={i}>{txt}</p>) )}
			</li>)
			: null;
		let images = ["","_R", "_V"]
			.map(suffix => config.imageUrl + this.props.data.archief + "_" + this.props.data.fonds + "_" + this.props.data.inventarisNummer + suffix + ".jpg")
			.map(url => <img onError={function (e) { e.target.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" }} className="hide-on-error" src={url} />)
		let imageContainer = (
			<li className="document-thumbnails">
				<div className="no-images-available">(Er zijn geen afbeeldingen beschikbaar)</div>
				{images}
			</li>
		);

		return (
			<div className="entry">
				<h2>{this.props.data.title}</h2>
				<ul>
					<li>
						<label>Datum</label>
						{this.props.data.date}
					</li>
					<li>
						<label>Archief naam</label>
						{this.props.data.fondsNaam}
					</li>
					<li>
						<label>Signatuur</label>
						{this.props.data.signature}
					</li>
					{regest}
					<li>
						<label>Permanente url</label>
						<a href={this.props.data["^pid"]}>{this.props.data["^pid"]}</a>
					</li>
					{link}
					<li>
						<label>Inventaristekst</label>
						{this.props.data.inventaristekst.map((txt, i) => (<p key={i}>{txt}</p>) )}
					</li>
					{imageContainer}
					{this.renderRelations("isCopyOf", form)}
					{this.renderRelations("isCopiedBy", inverseForm)}
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
	onChange:  React.PropTypes.func.isRequired,
	user: React.PropTypes.object
};

export default Entry;

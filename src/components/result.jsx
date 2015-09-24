import React from "react";
import ExternalIcon from "./icons/external";

class Result extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			moreInfoOpen: false
		};
		this.documentClickListener = this.onDocumentClick.bind(this);
	}

	componentDidMount() {
		document.addEventListener("click", this.documentClickListener);
	}

	componentWillUnmount() {
		document.removeEventListener("click", this.documentClickListener);
	}

	onDocumentClick(ev) {
		if (this.state.moreInfoOpen && !React.findDOMNode(this).contains(ev.target)) {
			this.setState({
				moreInfoOpen: false
			}, this.props.onSelect.bind(null));

		}
	}

	toggleMoreInfo(data) {
		this.setState({
			moreInfoOpen: !this.state.moreInfoOpen
		}, this.props.onSelect.bind(data));
	}


	onViewClick(data) {
		this.props.onSelect({...data, editThisRecord: true});
	}


	render() {
		let metadata = this.props.data.data;
		let links = this.props.data.data.links.length > 0 ? [
				(<li><a href={this.props.data.data.links[0].url} target="_blank">Archief <ExternalIcon /></a></li>),
				(<a className="button" href={this.props.data.data.links[0].url} target="_blank">Ga naar archief</a>)
			] : [null, null];

		return (
			<li className={this.state.moreInfoOpen ? "more-info-opened" : null}>
				<label onClick={this.toggleMoreInfo.bind(this, this.props.data)}>{this.props.data.displayName}</label>
				<span className="result-date">
					{this.props.data.data.date}
				</span>
				<div className="more-info">
					<img src="https://afbeeldingen.gahetna.nl/naa/thumb/500x500/320bb740-ee94-0f19-d611-e3c4dee1b3c2.jpg" />
					<ul className="metadata">
						<li>
							<label>Inventaristekst</label>
							{metadata.inventaristekst.map((txt, i) => (<p key={i}>{txt}</p>) )}
						</li>
						<li>
							<label>Signatuur</label>
							<span>{["archief", "fonds", "inventarisNummer"].map((key) => metadata[key]).join("-")} </span>
						</li>
						{links[0]}
					</ul>
				</div>
				<a className="button" onClick={this.toggleMoreInfo.bind(this, this.props.data)}>
					Meer info
				</a>
				{links[1]}
				<a className="button edit" onClick={this.onViewClick.bind(this, this.props.data)} >
					Tonen
				</a>
			</li>
		)
	}
}

Result.propTypes = {
	data: React.PropTypes.object,
	onSelect: React.PropTypes.func.isRequired
}

export default Result;
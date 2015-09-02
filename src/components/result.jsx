import React from "react";


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

	render() {
		return (
			<li className={this.state.moreInfoOpen ? "more-info-opened" : null}>
				<label onClick={this.toggleMoreInfo.bind(this, this.props.data)}>{this.props.data.displayName}</label>
				<span className="result-date">
					{this.props.data.data.date}
				</span>
				<div className="more-info">
					<img src="https://afbeeldingen.gahetna.nl/naa/thumb/500x500/320bb740-ee94-0f19-d611-e3c4dee1b3c2.jpg" />
					<ul className="metadata">
						<li><label>Gedrukt:</label><span>Mock data</span></li>
						<li><a href="http://example.com" target="_blank">
							http://example.com
						</a></li>
					</ul>
				</div>
				<a className="button" onClick={this.toggleMoreInfo.bind(this, this.props.data)}>
					Meer info
				</a>
				<a className="button" href="http://example.com" target="_blank">
					Ga naar archief
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
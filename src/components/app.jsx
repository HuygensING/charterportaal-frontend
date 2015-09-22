import config from "../config";
import {receiveUser} from "../actions/user";
import appStore from "../app-store";
import React from "react";
import {Login, Federated} from "hire-login";
import Search from "./search";

class App extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			user: null
		};
	}
	componentDidMount() {
		this.unsubscribe = appStore.subscribe(() =>
			this.setState(appStore.getState())
		);
	}

	componentWillUnmount() {
		this.unsubscribe();
	}

	handleLoginChange(response) {
		if (response.authenticated && response.token != null) {
			appStore.dispatch(receiveUser({
				displayName: response.userData.displayName,
				email: response.userData.email,
				token: response.token
			}));
		}
	}

	render() {
		return (
			<div>
				<header>
					<img 
						height="66px"
						src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAADTCAMAAAAMEN4/AAAAA3NCSVQICAjb4U/gAAABcVBMVEX///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD////7+/v5+fn39/f19fXx8fHv7+/t7e3r6+vo6Ojn5+fl5eXk5OTh4eHf39/d3d3b29vZ2dnX19fV1dXT09PR0dHPz8/MzMzJycnHx8fFxcXDw8PBwcG/v7+9vb27u7u5ubm3t7e1tbW0tLSxsbGvr6+tra2pqamnp6elpaWjo6OgoKCfn5+dnZ2ZmZmVlZWTk5OSkpKPj4+Li4uHh4eFhYWDg4OBgYF+fn58fHx6enp4eHh2dnZ0dHRycnJwcHBsbGxqampmZmZjY2NgYGBcXFxaWlpYWFhWVlZUVFRSUlJQUFBOTk5MTExISEhFRUVDQ0NAQEA+Pj48PDw6Ojo4ODg2NjYzMzMwMDAuLi4sLCwoKCgmJiYkJCQiIiIgICAcHBwaGhoYGBgUFBQSEhIQEBAODg4KCgoICAgGBgYEBAQAAAAocXdFAAAAe3RSTlMAESIzRFVmd4iZqrvM3e7////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9oEwhAAAACXBIWXMAAAsSAAALEgHS3X78AAAAHHRFWHRTb2Z0d2FyZQBBZG9iZSBGaXJld29ya3MgQ1M26LyyjAAAABV0RVh0Q3JlYXRpb24gVGltZQA4LzE5LzEz6vpq7AAAHWJJREFUeJztXfljHcWRfnPfLcBystnIhBDbHHJCdmW8RLYhBiKFI4JEwLKCBNkYFJxEJkY+NH/99t3V17yZd0hPz3y/6Gl6jp5vqqurqqu7R6PFQ1SgliI+7ZosPKKybZs8bTBZ4WnXZcERli0qCEmYrOq0K7PYCIoWZQH5lbUt+lGwupAiTtUo+VFjdSOu24JRNUqxXP3IlR+4BdYR/0lUfHS61VlopKjN1M+2DNynJSdWocUFboFClIjNgDychHX7lAtcEGcVVueoLos8o+Zo7hYr3FBx83wqusgozfPUYAHzVDatgcpNR5gzsx6l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"/>
					<div style={{float: "right"}}>
						<Login
							appId="Charter"
							headers={{VRE_ID: "Charter"}}
							onChange={this.handleLoginChange.bind(this)}
							userUrl={config.userUrl}>
							<Federated url={config.federatedAuthenticateUrl} />
						</Login>
					</div>
					<h1>Charterportaal</h1>
				</header>
				<div className="search">
					<Search user={this.state.user} />
				</div>
				<div className="edit">
					edit here
				</div>
			</div>
		)
	}
}

export default App;


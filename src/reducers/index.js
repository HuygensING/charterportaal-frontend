import {combineReducers} from "redux";

import user from "./user";
import entry from "./entry";


export default combineReducers({
	user: user,
	entry: entry
});
let initialState = {
	data: null
};


export default function(state=initialState, action) {
	switch (action.type) {
		case "SELECT_ENTRY":
			return {...state, ...action.data};
		default:
			return state;
	}
}
import axios from "axios";


export default {
    ajaxGet (api, cb) {
        axios.get(api)
            .then(cb)
            .catch(err => {
                console.log(err);
            })
    },
    ajaxPost (api, post, cb) {
        axios.post(api, post).then(cb)
        .catch(err => {
            console.log(err);
        })
    },
    ajaxGetWithParam (api, params, cb){
        axios.get(api, params)
            .then(cb)
            .catch(err => {
                console.log(err);
            })  
    }
}
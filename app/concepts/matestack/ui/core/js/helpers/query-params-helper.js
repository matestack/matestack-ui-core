const updateQueryParams = (key, value, url) => {
    if (!url) url = window.location.href;
    let re = new RegExp(`([?&])${key}=.*?(&|#|$)(.*)`, "gi"), hash;

    if (re.test(url)) {
        if (typeof value !== 'undefined' && value !== null)
            return url.replace(re, `$1${key}=${value}$2$3`);
        else {
            hash = url.split('#');
            url = hash[0].replace(re, '$1$3').replace(/(&|\?)$/, '');
            if (typeof hash[1] !== 'undefined' && hash[1] !== null)
                url += `#${hash[1]}`;
            return url;
        }
    }
    else {
        if (typeof value !== 'undefined' && value !== null) {
            const separator = url.indexOf('?') !== -1 ? '&' : '?';
            hash = url.split('#');
            url = `${hash[0]}${separator}${key}=${value}`;
            if (typeof hash[1] !== 'undefined' && hash[1] !== null)
                url += `#${hash[1]}`;
            return url;
        }
        else
            return url;
    }
};

const getQueryParam = (name, url) => {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    const regex = new RegExp(`[?&]${name}(=([^&#]*)|&|#|$)`), results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
};

const queryParamsToObject = () => {
  const search = window.location.search.substring(1);
  if(search.length === 0){
    return {}
  } else {
    const result = JSON.parse(
      `{"${search.replace(/&/g, '","').replace(/=/g,'":"')}"}`,
      (key, value) => { return key===""?value:decodeURIComponent(value) }
    );
    return result;
  }
};

export default {
  updateQueryParams: updateQueryParams,
  getQueryParam: getQueryParam,
  queryParamsToObject: queryParamsToObject
}

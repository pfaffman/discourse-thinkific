import { withPluginApi } from "discourse/lib/plugin-api";

function initializeDiscourseThinkific(api) {
 let cookie = $.cookie('thinkific_redirect');
 let currentUser = api.getCurrentUser();

 if(cookie && currentUser)  {
  $.removeCookie('thinkific_redirect');
  window.location.href = cookie;
  return;
 }
}

export default {
  name: "discourse-thinkific",

  initialize() {
    withPluginApi("0.8.31", initializeDiscourseThinkific);
  }
};

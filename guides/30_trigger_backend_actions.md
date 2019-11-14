Quite often we want to call all kinds of backend actions on a specific UI Event.
Imagine you want to build a list of Active Record instances, each having a "delete" button. After
clicking that button, you would like to see an updated list and probably success
notification.

**How would it be implemented with a classic Rails view?**

Within a classic Rails view, you would add a link pointing to the route of the controller action.
The controller action will delete the instance and usually redirects back to the list
maybe adding a flash message.

--> When clicked on the UI, the browser performs a request, the backend action handles the data
manipulation and afterwards the browser follows the redirect and performs a **full page load**
in order to display the updated list of instances, showing one element less and the flash message.

**How would it be implemented with a Javascript frontend application**

Initially, a Javascript frontend would get the Active Record instances by calling the backend API,
which responds usually with an array of JSON-representations of the Active Record instances. This array
is then stored in the Javascript frontend application as part of the clients "state".
When clicking a delete button on the UI, the Javascript frontend application would perform
an explicit AJAX Request towards the backends API, which routes
down to a controller action. Again, this controller action then handles the data manipulation and usually responds
with a JSON body and a HTTP status code. The Javascript client receives this response and can then delete the instance
from the array it initially got from the backend API. Usually this array is bound to a rendering mechanism of a
Javascript framework like Vue.js, Angular or React. The framework then takes care of updating the DOM **without a full page reload**

const isNavigatingToAnotherPage = function(currentLocation, popstateEvent) {
  const targetLocation = popstateEvent.target.location;

  // omits hash by design
  return currentLocation.pathname !== targetLocation.pathname ||
    currentLocation.origin !== targetLocation.origin ||
    currentLocation.search !== targetLocation.search
}

export default isNavigatingToAnotherPage

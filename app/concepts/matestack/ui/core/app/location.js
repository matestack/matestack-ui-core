const isNavigatingToAnotherPage = function(currentLocation, targetLocation) {

  // omits hash by design
  return currentLocation.pathName !== targetLocation.pathname ||
    currentLocation.origin !== targetLocation.origin ||
    currentLocation.search !== targetLocation.search
}

export default isNavigatingToAnotherPage

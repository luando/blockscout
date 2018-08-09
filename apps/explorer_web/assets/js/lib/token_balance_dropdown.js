import $ from 'jquery'

const renderLoading = () => {
  return `<p class="dropdown-item mb-0">Loading...</p>`
}

const renderError = () => {
  return `<p class="dropdown-item mb-0">Error. Please, try again.</p>`
}

const tokenBalanceDropdown = (element) => {
  const $element = $(element)
  const $dropdownMenu = $element.find('.dropdown-menu')
  const apiPath = $element.data('api-path')

  $element.on('show.bs.dropdown', (e) => {
    $dropdownMenu.html(renderLoading())

    $.get(apiPath)
      .done(response => $dropdownMenu.html(response))
      .fail(() => $dropdownMenu.html(renderError()))
  })
}

$('[data-token-balance-dropdown]').each((_index, element) => tokenBalanceDropdown(element))

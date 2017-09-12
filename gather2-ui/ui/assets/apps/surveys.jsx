import React from 'react'
import ReactDOM from 'react-dom'
import { IntlProvider } from 'react-intl'

import { FetchUrlsContainer, PaginationContainer } from './components'

import Survey from './survey/Survey'
import SurveyForm from './survey/SurveyForm'
import SurveysList from './survey/SurveysList'

// Include this to enable HMR for this module
if (module.hot) {
  module.hot.accept()
}

/*
This is the surveys app
*/

const appElement = document.getElementById('surveys-app')
const surveyId = appElement.getAttribute('data-survey-id')
const action = appElement.getAttribute('data-action')

let component
switch (action) {
  case 'add':
    component = <SurveyForm survey={{}} />
    break

  case 'edit':
    const editUrls = [
      {
        name: 'survey',
        url: `/core/surveys/${surveyId}.json`
      }
    ]

    component = <FetchUrlsContainer urls={editUrls} targetComponent={SurveyForm} />
    break

  case 'view':
    const viewUrls = [
      {
        name: 'survey',
        url: `/core/surveys-stats/${surveyId}.json`
      }
    ]

    component = <FetchUrlsContainer urls={viewUrls} targetComponent={Survey} />
    break

  default:
    component = (
      <PaginationContainer
        pageSize={12}
        url='/core/surveys-stats.json?'
        position='top'
        listComponent={SurveysList}
      />
    )
    break
}

ReactDOM.render(
  <IntlProvider defaultLocale='en' locale={navigator.locale || 'en'}>
    { component }
  </IntlProvider>,
  appElement)

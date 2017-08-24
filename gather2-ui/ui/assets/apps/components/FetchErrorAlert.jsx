import React, { Component } from 'react'
import { FormattedMessage } from 'react-intl'

export default class FetchErrorAlert extends Component {
  render () {
    return (
      <div data-qa='data-erred' className='container-fluid'>
        <p className='alert alert-danger'>
          <i className='fa fa-warning' />
          &nbsp;
          <FormattedMessage
            id='alert.error.fetch'
            defaultMessage={`
              Request was not successful, maybe requested resource does
              not exists or there was a server error while requesting for it.
            `} />
        </p>
      </div>
    )
  }
}

import { Form } from '@sitecore-jss/sitecore-jss-react-forms';
import React from 'react';
import { NextRouter, withRouter } from 'next/router';
import { sitecoreApiHost, sitecoreApiKey } from 'temp/config';

const JssNextForm = ({ fields, router }: { fields: any; router: NextRouter }) => {
  return (
    <Form
      language={router.locale}
      form={fields}
      sitecoreApiHost={sitecoreApiHost}
      sitecoreApiKey={sitecoreApiKey}
      onRedirect={(url) => router.push(url)}
    />
  );
};

export default withRouter(JssNextForm);

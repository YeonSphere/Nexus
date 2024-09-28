import React, { useState } from 'react';
import styled from 'styled-components';

const NavigationContainer = styled.nav`
  display: flex;
  align-items: center;
  width: 100%;
`;

const AddressBar = styled.input`
  flex: 1;
  padding: 8px;
  border: 1px solid ${props => props.theme.borderColor};
  border-radius: 4px;
  background-color: ${props => props.theme.inputBackgroundColor};
  color: ${props => props.theme.textColor};
`;

const NavigationButton = styled.button`
  margin: 0 5px;
  padding: 8px 12px;
  background-color: ${props => props.theme.buttonBackgroundColor};
  color: ${props => props.theme.buttonTextColor};
  border: none;
  border-radius: 4px;
  cursor: pointer;

  &:hover {
    background-color: ${props => props.theme.buttonHoverBackgroundColor};
  }
`;

const Navigation: React.FC = () => {
  const [url, setUrl] = useState('');

  const handleUrlChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setUrl(event.target.value);
  };

  const handleKeyPress = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter') {
      window.api.navigateToUrl(url);
    }
  };

  const handleGoBack = () => {
    window.api.goBack();
  };

  const handleGoForward = () => {
    window.api.goForward();
  };

  const handleRefresh = () => {
    // Removed refreshPage call as it's not defined in the API
  };

  return (
    <NavigationContainer>
      <NavigationButton onClick={handleGoBack}>Back</NavigationButton>
      <NavigationButton onClick={handleGoForward}>Forward</NavigationButton>
      <NavigationButton onClick={handleRefresh}>Refresh</NavigationButton>
      <AddressBar
        type="text"
        value={url}
        onChange={handleUrlChange}
        onKeyPress={handleKeyPress}
        placeholder="Enter URL or search"
      />
    </NavigationContainer>
  );
};

export default Navigation;

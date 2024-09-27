import React, { useState, useCallback } from 'react';
import styled from 'styled-components';

// Styled components for the navigation bar
const NavContainer = styled.nav`
  display: flex;
  align-items: center;
  background-color: #f0f0f0;
  padding: 10px;
  border-bottom: 1px solid #ccc;
`;

const NavButton = styled.button`
  background-color: #ffffff;
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 5px 10px;
  margin: 0 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;

  &:hover {
    background-color: #e0e0e0;
  }
`;

const UrlInput = styled.input`
  flex-grow: 1;
  padding: 5px 10px;
  font-size: 16px;
  border: 1px solid #ccc;
  border-radius: 4px;
  margin: 0 10px;
`;

const Navigation: React.FC = () => {
  const [url, setUrl] = useState('');

  const handleNavigate = useCallback(() => {
    if (url) {
      // TODO: Implement actual navigation logic
      console.log('Navigating to:', url);
      // Here you would typically call a function to load the URL in the browser
    }
  }, [url]);

  const handleKeyPress = useCallback((e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleNavigate();
    }
  }, [handleNavigate]);

  return (
    <NavContainer>
      <NavButton onClick={() => console.log('Back')} title="Go back">&#8592;</NavButton>
      <NavButton onClick={() => console.log('Forward')} title="Go forward">&#8594;</NavButton>
      <NavButton onClick={() => console.log('Reload')} title="Reload page">&#8635;</NavButton>
      <UrlInput
        type="text"
        value={url}
        onChange={(e) => setUrl(e.target.value)}
        onKeyPress={handleKeyPress}
        placeholder="Enter URL"
      />
      <NavButton onClick={handleNavigate}>Go</NavButton>
    </NavContainer>
  );
};

export default Navigation;

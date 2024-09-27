import React, { useState } from 'react';
import styled from 'styled-components';

// Styled components for the navigation bar
const NavContainer = styled.nav`
  display: flex;
  align-items: center;
`;

const NavButton = styled.button`
  // Add styles for navigation buttons
`;

const UrlInput = styled.input`
  // Add styles for URL input
`;

const Navigation: React.FC = () => {
  const [url, setUrl] = useState('');

  const handleNavigate = () => {
    // TODO: Implement navigation logic
    console.log('Navigating to:', url);
  };

  return (
    <NavContainer>
      <NavButton onClick={() => console.log('Back')}>&#8592;</NavButton>
      <NavButton onClick={() => console.log('Forward')}>&#8594;</NavButton>
      <NavButton onClick={() => console.log('Reload')}>&#8635;</NavButton>
      <UrlInput
        type="text"
        value={url}
        onChange={(e) => setUrl(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && handleNavigate()}
      />
      <NavButton onClick={handleNavigate}>Go</NavButton>
    </NavContainer>
  );
};

export default Navigation;

import React, { useState } from 'react';
import Web3 from 'web3';
import './AdminPage.css';

const AdminPage = () => {
  const [faucetStatus, setFaucetStatus] = useState(true);

  const handleToggleFaucetStatus = async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send('eth_requestAccounts', []);
      const signer = provider.getSigner();
      const faucetContract = new ethers.Contract(faucetAddress, faucetABI, signer);
      await faucetContract.toggleFaucetStatus();
      setFaucetStatus(!faucetStatus);
    } catch (error) {
      console.error('Failed to toggle faucet status', error);
    }
  };

  return (
    <div className="admin-container">
      <h1>Faucet ETH Kipu - Scroll Sepolia</h1>
      <h2>Página de administración</h2>
      <button onClick={handleToggleFaucetStatus}>{faucetStatus ? 'Apagar Faucet' : 'Encender Faucet'}</button>
      <div>
        <h3>Whitelist</h3>
        {/* Code to display and manage the whitelist */}
      </div>
      {/* More admin features as needed */}
    </div>
  );
};

export default AdminPage;

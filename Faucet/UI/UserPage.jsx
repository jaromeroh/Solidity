import React, { useState } from 'react';
import { ethers } from 'ethers';
import './UserPage.css';

const UserPage = () => {
  const [userAddress, setUserAddress] = useState('');
  const [status, setStatus] = useState('');

  const handleWithdraw = async () => {
    if (!userAddress) {
      setStatus('Por favor ingresa una dirección válida.');
      return;
    }

    try {
      // Connect to ethers.js
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send('eth_requestAccounts', []);
      const signer = provider.getSigner();
      const faucetContract = new ethers.Contract(faucetAddress, faucetABI, signer);
      const amount = ethers.utils.parseEther('0.1');

      await faucetContract.requestWithdraw(userAddress, amount);
      setStatus('Solicitud enviada con éxito. Esperando confirmación...');
    } catch (error) {
      console.error(error);
      setStatus('Ocurrió un error durante la solicitud.');
    }
  };

  return (
    <div className="faucet-container">
      <h1>Faucet ETH Kipu - Scroll Sepolia</h1>
      <p>Recibe 0.1 ETH para tus ejercicios del Ethereum Developer Pack de ETH Kipu</p>
      <input
        type="text"
        placeholder="Ingresa tu address (0x...)"
        value={userAddress}
        onChange={(e) => setUserAddress(e.target.value)}
      />
      <button onClick={handleWithdraw}>Envíame ETH</button>
      <div className="recaptcha">No soy un robot</div>
      <p>{status}</p>
      <table>
        <thead>
          <tr>
            <th>Tus transacciones</th>
            <th>Cuando</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <a href="#">0xcac6c515cb30cb2e904847f2961ba01ebe5ce93</a>
            </td>
            <td>Hace 5 minutos</td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};

export default UserPage;

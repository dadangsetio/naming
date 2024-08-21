import { useState, useEffect } from 'react';

const backendUrl = 'https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=oq35z-viaaa-aaaal-qjqkq-cai';

function App() {
  const [greeting, setGreeting] = useState('');
  const [nameCount, setNameCount] = useState(null);
  const [totalSubmissions, setTotalSubmissions] = useState(0);

  useEffect(() => {
    updateTotalSubmissions();
  }, []);

  async function updateTotalSubmissions() {
    try {
      const response = await fetch(`${backendUrl}getTotalSubmissions`);
      const total = await response.json();
      setTotalSubmissions(total);
    } catch (error) {
      console.error('Error fetching total submissions:', error);
    }
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    try {
      const greetResponse = await fetch(`${backendUrl}greet?name=${encodeURIComponent(name)}`);
      const greetText = await greetResponse.text();
      setGreeting(greetText);

      const rankResponse = await fetch(`${backendUrl}getNameRank?name=${encodeURIComponent(name)}`);
      const count = await rankResponse.json();
      setNameCount(count);
      
      updateTotalSubmissions();
    } catch (error) {
      console.error('Error submitting name:', error);
    }
  }

  return (
    <main>
      <img src="/logo2.svg" alt="DFINITY Logo" />
      <h1>Name Counter</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="name">Enter your name: </label>
          <input id="name" type="text" required />
        </div>
        <button type="submit">Submit</button>
      </form>
      {greeting && <section id="greeting">{greeting}</section>}
      {nameCount !== null && (
        <section id="nameCount">
          <h2>Name Statistics:</h2>
          <p>Your name has been submitted {nameCount} time(s)</p>
        </section>
      )}
      <section id="totalSubmissions">
        <p>Total name submissions: {totalSubmissions}</p>
      </section>
    </main>
  );
}

export default App;
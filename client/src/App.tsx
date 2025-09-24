import React from 'react';
import { Provider } from 'react-redux';
import { store } from './store/store';
import QuestionInput from './components/QuestionInput';
import ResponseDisplay from './components/ResponseDisplay';
import './App.css';

function App() {
  return (
    <Provider store={store}>
      <div className="app">
        <header className="app-header">
          <h1>RAG Demo</h1>
          <p>Ask questions about product reviews and get AI-powered answers</p>
        </header>

        <main className="app-main">
          <div className="container">
            <QuestionInput />
            <ResponseDisplay />
          </div>
        </main>

        <footer className="app-footer">
          <p>Powered by Ruby/Sinatra backend with PostgreSQL vector search</p>
        </footer>
      </div>
    </Provider>
  );
}

export default App;
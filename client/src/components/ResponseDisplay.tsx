import React from 'react';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { clearResponse, clearError } from '../store/ragSlice';
import type { ReviewSource } from '../types';

const ResponseDisplay: React.FC = () => {
  const dispatch = useAppDispatch();
  const { response, error } = useAppSelector((state) => state.rag);

  if (error) {
    return (
      <div className="response-display error">
        <div className="error-content">
          <h3>Error</h3>
          <p>{error}</p>
          <button onClick={() => dispatch(clearError())}>Dismiss</button>
        </div>
      </div>
    );
  }

  if (!response) {
    return null;
  }

  return (
    <div className="response-display">
      <div className="response-header">
        <h3>Answer</h3>
        <button
          className="clear-btn"
          onClick={() => dispatch(clearResponse())}
          title="Clear response"
        >
          ×
        </button>
      </div>

      <div className="answer">
        <p>{response.answer}</p>
      </div>

      {response.sources && response.sources.length > 0 && (
        <div className="sources">
          <h4>Sources ({response.sources.length} reviews)</h4>
          <div className="sources-list">
            {response.sources.map((source: ReviewSource, index: number) => (
              <div key={index} className="source-item">
                <div className="source-header">
                  <span className="product-name">{source.product_name}</span>
                  <div className="rating">
                    {'★'.repeat(source.rating)}{'☆'.repeat(5 - source.rating)}
                    <span className="rating-number">({source.rating}/5)</span>
                  </div>
                </div>
                <div className="source-content">
                  <p>"{source.content}"</p>
                  <cite>- {source.author}</cite>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default ResponseDisplay;
import React, { useState } from 'react';
import { useAppDispatch, useAppSelector } from '../store/hooks';
import { askQuestion, setQuestion } from '../store/ragSlice';

const QuestionInput: React.FC = () => {
  const dispatch = useAppDispatch();
  const { question, loading } = useAppSelector((state) => state.rag);
  const [productId, setProductId] = useState<string>('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (question.trim()) {
      dispatch(askQuestion({
        question,
        productId: productId ? parseInt(productId) : undefined
      }));
    }
  };

  const handleQuestionChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    dispatch(setQuestion(e.target.value));
  };

  return (
    <div className="question-input">
      <h2>Ask about Product Reviews</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="productId">Product (optional):</label>
          <select
            id="productId"
            value={productId}
            onChange={(e) => setProductId(e.target.value)}
            disabled={loading}
          >
            <option value="">All Products</option>
            <option value="1">MacBook Pro 16-inch</option>
            <option value="2">iPhone 15 Pro</option>
            <option value="3">AirPods Pro (2nd generation)</option>
          </select>
        </div>

        <div className="form-group">
          <label htmlFor="question">Your Question:</label>
          <textarea
            id="question"
            value={question}
            onChange={handleQuestionChange}
            placeholder="e.g., What do customers think about battery life?"
            disabled={loading}
            rows={3}
          />
        </div>

        <button type="submit" disabled={loading || !question.trim()}>
          {loading ? 'Getting Answer...' : 'Ask Question'}
        </button>
      </form>
    </div>
  );
};

export default QuestionInput;
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import type { PayloadAction } from '@reduxjs/toolkit';
import type { RAGState, RAGResponse } from '../types';

const API_BASE_URL = 'http://localhost:4567';

export const askQuestion = createAsyncThunk(
  'rag/askQuestion',
  async ({ question, productId }: { question: string; productId?: number }) => {
    const response = await fetch(`${API_BASE_URL}/ask`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        question,
        product_id: productId,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || 'Failed to get answer');
    }

    return await response.json() as RAGResponse;
  }
);

const initialState: RAGState = {
  question: '',
  response: null,
  loading: false,
  error: null,
};

const ragSlice = createSlice({
  name: 'rag',
  initialState,
  reducers: {
    setQuestion: (state, action: PayloadAction<string>) => {
      state.question = action.payload;
    },
    clearResponse: (state) => {
      state.response = null;
      state.error = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(askQuestion.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(askQuestion.fulfilled, (state, action) => {
        state.loading = false;
        state.response = action.payload;
        state.error = null;
      })
      .addCase(askQuestion.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || 'An error occurred';
      });
  },
});

export const { setQuestion, clearResponse, clearError } = ragSlice.actions;
export default ragSlice.reducer;
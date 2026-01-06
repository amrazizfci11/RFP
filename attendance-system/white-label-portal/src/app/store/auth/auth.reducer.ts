import { createReducer, on } from '@ngrx/store';
import { AuthActions, User } from './auth.actions';

export interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
}

export const initialState: AuthState = {
  user: null,
  accessToken: null,
  refreshToken: null,
  isAuthenticated: false,
  loading: false,
  error: null
};

export const authReducer = createReducer(
  initialState,

  on(AuthActions.login, (state) => ({
    ...state,
    loading: true,
    error: null
  })),

  on(AuthActions.loginSuccess, (state, { response }) => ({
    ...state,
    user: response.user,
    accessToken: response.accessToken,
    refreshToken: response.refreshToken,
    isAuthenticated: true,
    loading: false,
    error: null
  })),

  on(AuthActions.loginFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),

  on(AuthActions.logout, (state) => ({
    ...state,
    loading: true
  })),

  on(AuthActions.logoutSuccess, () => ({
    ...initialState
  })),

  on(AuthActions.refreshTokenSuccess, (state, { accessToken, refreshToken }) => ({
    ...state,
    accessToken,
    refreshToken
  })),

  on(AuthActions.refreshTokenFailure, () => ({
    ...initialState
  })),

  on(AuthActions.updateProfileSuccess, (state, { user }) => ({
    ...state,
    user
  })),

  on(AuthActions.updateProfileFailure, (state, { error }) => ({
    ...state,
    error
  }))
);

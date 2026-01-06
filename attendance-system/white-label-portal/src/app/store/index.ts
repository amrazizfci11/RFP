import { ActionReducerMap, MetaReducer } from '@ngrx/store';
import { authReducer, AuthState } from './auth/auth.reducer';
import { companyReducer, CompanyState } from './company/company.reducer';

export interface AppState {
  auth: AuthState;
  companies: CompanyState;
}

export const reducers: ActionReducerMap<AppState> = {
  auth: authReducer,
  companies: companyReducer
};

export const metaReducers: MetaReducer<AppState>[] = [];

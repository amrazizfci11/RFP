import { createFeatureSelector, createSelector } from '@ngrx/store';
import { CompanyState } from './company.reducer';

export const selectCompanyState = createFeatureSelector<CompanyState>('companies');

export const selectCompanies = createSelector(
  selectCompanyState,
  (state) => state.companies
);

export const selectSelectedCompany = createSelector(
  selectCompanyState,
  (state) => state.selectedCompany
);

export const selectCompanyTotalCount = createSelector(
  selectCompanyState,
  (state) => state.totalCount
);

export const selectCompanyFilters = createSelector(
  selectCompanyState,
  (state) => state.filters
);

export const selectCompanyLoading = createSelector(
  selectCompanyState,
  (state) => state.loading
);

export const selectCompanyError = createSelector(
  selectCompanyState,
  (state) => state.error
);

import { createReducer, on } from '@ngrx/store';
import { Company, CompanyActions, CompanyFilters } from './company.actions';

export interface CompanyState {
  companies: Company[];
  selectedCompany: Company | null;
  totalCount: number;
  filters: CompanyFilters;
  loading: boolean;
  error: string | null;
}

export const initialState: CompanyState = {
  companies: [],
  selectedCompany: null,
  totalCount: 0,
  filters: {
    page: 1,
    pageSize: 10
  },
  loading: false,
  error: null
};

export const companyReducer = createReducer(
  initialState,

  on(CompanyActions.loadCompanies, (state, { filters }) => ({
    ...state,
    filters,
    loading: true,
    error: null
  })),

  on(CompanyActions.loadCompaniesSuccess, (state, { response }) => ({
    ...state,
    companies: response.items,
    totalCount: response.totalCount,
    loading: false
  })),

  on(CompanyActions.loadCompaniesFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),

  on(CompanyActions.loadCompany, (state) => ({
    ...state,
    loading: true,
    error: null
  })),

  on(CompanyActions.loadCompanySuccess, (state, { company }) => ({
    ...state,
    selectedCompany: company,
    loading: false
  })),

  on(CompanyActions.loadCompanyFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),

  on(CompanyActions.createCompany, (state) => ({
    ...state,
    loading: true,
    error: null
  })),

  on(CompanyActions.createCompanySuccess, (state, { company }) => ({
    ...state,
    companies: [company, ...state.companies],
    totalCount: state.totalCount + 1,
    loading: false
  })),

  on(CompanyActions.createCompanyFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),

  on(CompanyActions.updateCompanySuccess, (state, { company }) => ({
    ...state,
    companies: state.companies.map(c => c.id === company.id ? company : c),
    selectedCompany: state.selectedCompany?.id === company.id ? company : state.selectedCompany,
    loading: false
  })),

  on(CompanyActions.deleteCompanySuccess, (state, { id }) => ({
    ...state,
    companies: state.companies.filter(c => c.id !== id),
    totalCount: state.totalCount - 1,
    loading: false
  })),

  on(CompanyActions.activateCompanySuccess, CompanyActions.deactivateCompanySuccess, (state, { company }) => ({
    ...state,
    companies: state.companies.map(c => c.id === company.id ? company : c),
    selectedCompany: state.selectedCompany?.id === company.id ? company : state.selectedCompany
  })),

  on(CompanyActions.clearSelectedCompany, (state) => ({
    ...state,
    selectedCompany: null
  })),

  on(CompanyActions.clearError, (state) => ({
    ...state,
    error: null
  }))
);

import { createActionGroup, emptyProps, props } from '@ngrx/store';

export interface Company {
  id: string;
  name: string;
  nameAr?: string;
  email: string;
  phone?: string;
  commercialRegister?: string;
  taxNumber?: string;
  address?: string;
  logoUrl?: string;
  subscriptionStatus: string;
  subscriptionPackageId?: string;
  subscriptionPackageName?: string;
  subscriptionStartDate?: string;
  subscriptionEndDate?: string;
  employeeCount: number;
  maxEmployees: number;
  createdAt: string;
  isActive: boolean;
}

export interface CompanyFilters {
  search?: string;
  status?: string;
  packageId?: string;
  page: number;
  pageSize: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export const CompanyActions = createActionGroup({
  source: 'Companies',
  events: {
    'Load Companies': props<{ filters: CompanyFilters }>(),
    'Load Companies Success': props<{ response: PaginatedResponse<Company> }>(),
    'Load Companies Failure': props<{ error: string }>(),
    'Load Company': props<{ id: string }>(),
    'Load Company Success': props<{ company: Company }>(),
    'Load Company Failure': props<{ error: string }>(),
    'Create Company': props<{ company: Partial<Company> }>(),
    'Create Company Success': props<{ company: Company }>(),
    'Create Company Failure': props<{ error: string }>(),
    'Update Company': props<{ id: string; company: Partial<Company> }>(),
    'Update Company Success': props<{ company: Company }>(),
    'Update Company Failure': props<{ error: string }>(),
    'Delete Company': props<{ id: string }>(),
    'Delete Company Success': props<{ id: string }>(),
    'Delete Company Failure': props<{ error: string }>(),
    'Activate Company': props<{ id: string }>(),
    'Activate Company Success': props<{ company: Company }>(),
    'Deactivate Company': props<{ id: string }>(),
    'Deactivate Company Success': props<{ company: Company }>(),
    'Clear Selected Company': emptyProps(),
    'Clear Error': emptyProps(),
  }
});

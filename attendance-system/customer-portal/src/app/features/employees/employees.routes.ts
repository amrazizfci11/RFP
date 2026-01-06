import { Routes } from '@angular/router';

export const EMPLOYEE_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./employee-list/employee-list.component').then(m => m.EmployeeListComponent),
    data: { title: 'Employees' }
  },
  {
    path: 'import',
    loadComponent: () => import('./employee-import/employee-import.component').then(m => m.EmployeeImportComponent),
    data: { title: 'Import Employees' }
  },
  {
    path: 'create',
    loadComponent: () => import('./employee-form/employee-form.component').then(m => m.EmployeeFormComponent),
    data: { title: 'Add Employee' }
  },
  {
    path: ':id',
    loadComponent: () => import('./employee-detail/employee-detail.component').then(m => m.EmployeeDetailComponent),
    data: { title: 'Employee Details' }
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./employee-form/employee-form.component').then(m => m.EmployeeFormComponent),
    data: { title: 'Edit Employee' }
  }
];

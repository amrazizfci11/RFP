import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, exhaustMap, catchError, tap } from 'rxjs/operators';
import { ToastrService } from 'ngx-toastr';
import { CompanyService } from '../../core/services/company.service';
import { CompanyActions } from './company.actions';

@Injectable()
export class CompanyEffects {
  private actions$ = inject(Actions);
  private companyService = inject(CompanyService);
  private router = inject(Router);
  private toastr = inject(ToastrService);

  loadCompanies$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.loadCompanies),
      exhaustMap(({ filters }) =>
        this.companyService.getCompanies(filters).pipe(
          map((response) => CompanyActions.loadCompaniesSuccess({ response })),
          catchError((error) => of(CompanyActions.loadCompaniesFailure({ error: error.message })))
        )
      )
    )
  );

  loadCompany$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.loadCompany),
      exhaustMap(({ id }) =>
        this.companyService.getCompany(id).pipe(
          map((company) => CompanyActions.loadCompanySuccess({ company })),
          catchError((error) => of(CompanyActions.loadCompanyFailure({ error: error.message })))
        )
      )
    )
  );

  createCompany$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.createCompany),
      exhaustMap(({ company }) =>
        this.companyService.createCompany(company).pipe(
          map((created) => CompanyActions.createCompanySuccess({ company: created })),
          catchError((error) => of(CompanyActions.createCompanyFailure({ error: error.message })))
        )
      )
    )
  );

  createCompanySuccess$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(CompanyActions.createCompanySuccess),
        tap(() => {
          this.toastr.success('Company created successfully');
          this.router.navigate(['/companies']);
        })
      ),
    { dispatch: false }
  );

  updateCompany$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.updateCompany),
      exhaustMap(({ id, company }) =>
        this.companyService.updateCompany(id, company).pipe(
          map((updated) => CompanyActions.updateCompanySuccess({ company: updated })),
          catchError((error) => of(CompanyActions.updateCompanyFailure({ error: error.message })))
        )
      )
    )
  );

  updateCompanySuccess$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(CompanyActions.updateCompanySuccess),
        tap(() => {
          this.toastr.success('Company updated successfully');
        })
      ),
    { dispatch: false }
  );

  deleteCompany$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.deleteCompany),
      exhaustMap(({ id }) =>
        this.companyService.deleteCompany(id).pipe(
          map(() => CompanyActions.deleteCompanySuccess({ id })),
          catchError((error) => of(CompanyActions.deleteCompanyFailure({ error: error.message })))
        )
      )
    )
  );

  deleteCompanySuccess$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(CompanyActions.deleteCompanySuccess),
        tap(() => {
          this.toastr.success('Company deleted successfully');
        })
      ),
    { dispatch: false }
  );

  activateCompany$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.activateCompany),
      exhaustMap(({ id }) =>
        this.companyService.activateCompany(id).pipe(
          map((company) => CompanyActions.activateCompanySuccess({ company })),
          catchError((error) => of(CompanyActions.updateCompanyFailure({ error: error.message })))
        )
      )
    )
  );

  deactivateCompany$ = createEffect(() =>
    this.actions$.pipe(
      ofType(CompanyActions.deactivateCompany),
      exhaustMap(({ id }) =>
        this.companyService.deactivateCompany(id).pipe(
          map((company) => CompanyActions.deactivateCompanySuccess({ company })),
          catchError((error) => of(CompanyActions.updateCompanyFailure({ error: error.message })))
        )
      )
    )
  );

  showError$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(
          CompanyActions.loadCompaniesFailure,
          CompanyActions.loadCompanyFailure,
          CompanyActions.createCompanyFailure,
          CompanyActions.updateCompanyFailure,
          CompanyActions.deleteCompanyFailure
        ),
        tap(({ error }) => {
          this.toastr.error(error);
        })
      ),
    { dispatch: false }
  );
}

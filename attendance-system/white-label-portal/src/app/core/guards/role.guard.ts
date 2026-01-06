import { inject } from '@angular/core';
import { CanActivateFn, Router, ActivatedRouteSnapshot } from '@angular/router';
import { Store } from '@ngrx/store';
import { map, take } from 'rxjs/operators';
import { selectUserRole } from '../../store/auth/auth.selectors';

export const roleGuard: CanActivateFn = (route: ActivatedRouteSnapshot) => {
  const store = inject(Store);
  const router = inject(Router);
  const requiredRoles = route.data['roles'] as string[];

  return store.select(selectUserRole).pipe(
    take(1),
    map((role) => {
      if (role && requiredRoles.includes(role)) {
        return true;
      }

      router.navigate(['/dashboard']);
      return false;
    })
  );
};

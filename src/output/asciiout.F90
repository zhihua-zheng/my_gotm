#include"cppdefs.h"
!-----------------------------------------------------------------------
!BOP
!
! !MODULE: asciiout --- saving the results in ASCII
!
! !INTERFACE:
   MODULE asciiout
!
! !DESCRIPTION:
!  This module contains three subroutines for writing model output in ASCII format.
!  The authors do not encourage using ASCII for output --- instead we recommend
!  NetCDF.
!
! !USES:
   IMPLICIT NONE
!
!  Default all is private.
   private
!
! !PUBLIC MEMBER FUNCTIONS:
   public init_ascii, do_ascii_out, close_ascii

   integer :: set
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!EOP
!-----------------------------------------------------------------------

   contains

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Open the file unit for writing
!
! !INTERFACE:
   subroutine init_ascii(fn,title,unit)
   IMPLICIT NONE
!
! !DESCRIPTION:
!  Opens a file giving in the {\tt output} namelist and connects
!  it with a unit number.
!
! !INPUT PARAMETERS:
   character(len=*), intent(in)        :: fn,title
!
! !INPUT/OUTPUT PARAMETERS:
   integer, intent(in)                 :: unit
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See asciiout module
!
!EOP
!-------------------------------------------------------------------------
!BOC
   open(unit,status='unknown',file=fn)
   write(unit,*) '# ',trim(title)
   set = 0
   return
   end subroutine init_ascii
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Save the model results to file
!
! !INTERFACE:
   subroutine do_ascii_out(nlev,timestr,unit)
!
! !DESCRIPTION:
!  Writes all calculated data to an ASCII file.
!
! !USES:
   use meanflow,     only: depth0,h,u,v,z,S,T,buoy
   use turbulence,   only: num,nucl,nuh,tke,eps,L
   use turbulence,   only: kb,epsb
   use observations, only: tprof,sprof,uprof,vprof,epsprof
!#ifdef SEDIMENT
!   use sediment, only: ascii_sediment
!#endif
!#ifdef SEDIMENT
!   use seagrass, only: ascii_seagrass
!#endif

   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: nlev
   CHARACTER(len=*), intent(in)        :: timestr
   integer, intent(in)                 :: unit
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See asciiout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: i
   REALTYPE                  :: d,epsprof_loc
   REALTYPE                  :: zz(0:nlev)
!
!-------------------------------------------------------------------------
!BOC
   set = set + 1
   write(unit,*) timestr,'  Set# ',set
   write(unit,112) 'z','u','v','T','S','buoy'
   d=0.
   do i=nlev,1,-1
      if (abs(u(i)).lt.1.e-32) u(i)=0.
      if (abs(v(i)).lt.1.e-32) v(i)=0.
      d=d+0.5*h(i)
      write(unit,114) z(i),u(i),v(i),T(i),S(i),buoy(i)
   end do

   write(unit,113) 'z','num','nucl','nuh','k','eps','L','kb','epsb'
   zz(1)=-depth0+h(1)
   do i=2,nlev
      zz(i)=zz(i-1)+h(i)
   end do
   do i=nlev-1,1,-1
      write(unit,115) zz(i),num(i),nucl(i),nuh(i),tke(i),eps(i),L(i),kb(i),epsb(i)
   end do

   write(unit,113) 'z','Tobs','Sobs','Uobs','Vobs','epsobs'
   epsprof_loc = -9999.0
   do i=nlev,1,-1
     if (allocated(epsprof)) epsprof_loc = epsprof(i)
     write(unit,116) z(i),tprof(i),sprof(i),uprof(i),vprof(i),epsprof_loc
   end do

112 format(A9,6(1x,A12))
113 format(A9,8(1x,A12))
114 format(F12.4,2(1x,E12.4E2),2(1x,F12.6),2(1x,E12.4E2))
115 format(F12.4,7(1x,E12.4E2))
116 format(F12.4,2(1x,F12.6),3(2x,E12.4E2))

!#ifdef SEDIMENT
!    call ascii_sediment(nlev,timestr)
!#endif
!#ifdef SEAGRASS
!    call ascii_seagrass(timestr)
!#endif

   return
   end subroutine do_ascii_out
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Close files used for saving model results
!
! !INTERFACE:
   subroutine close_ascii(unit)
   IMPLICIT NONE
!
! !DESCRIPTION:
!  Close the open ASCII file.
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: unit
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See asciiout module
!
!EOP
!-------------------------------------------------------------------------
!BOC
   LEVEL2 'Output has been written in ASCII'
   close(unit)

   return
   end subroutine close_ascii
!EOC

!-----------------------------------------------------------------------

   end module asciiout

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------

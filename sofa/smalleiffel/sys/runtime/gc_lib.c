/*
-- This file is  free  software, which  comes  along  with  SmallEiffel. This
-- software  is  distributed  in the hope that it will be useful, but WITHOUT
-- ANY  WARRANTY;  without  even  the  implied warranty of MERCHANTABILITY or
-- FITNESS  FOR A PARTICULAR PURPOSE. You can modify it as you want, provided
-- this header is kept unaltered, and a notification of the changes is added.
-- You  are  allowed  to  redistribute  it and sell it, alone or as a part of
-- another product.
--          Copyright (C) 1994-98 LORIA - UHP - CRIN - INRIA - FRANCE
--            Dominique COLNET and Suzanne COLLIN - colnet@loria.fr
--                       http://SmallEiffel.loria.fr
--
*/

/*
   This file (SmallEiffel/sys/runtime/gc_lib.c) is automatically included
   when the Garbage Collector is used (default, unless option -no_gc has been
   selected).
*/

void**stack_bottom;
mch**gcmt=NULL; /* Garbage Collector Main Table. */
int gcmt_max=2048;
int gcmt_used=0;
fsoc*fsocfl=NULL;
rsoc*rsocfl=NULL;
int gc_is_off=1;
unsigned int fsoc_count=0;
unsigned int rsoc_count=0;
void*gcmt_tail_addr=NULL;

void gc_sweep(void) {
  mch** p2 = gcmt;
  mch** p1 = gcmt+1;
  mch**eogcmt=gcmt+gcmt_used;
  if (FREE_CHUNK((*p2)->state_type)) {
    if (RSO_FREE_CHUNK == ((*p2)->state_type)) {
      ((rsoc*)(*p2))->next=NULL;
      rsocfl=((rsoc*)(*p2));
    }
    else {
      rsocfl=NULL;
    }
  }
  else {
    ((*gcmt)->swfp)(*p2);
    if (RSO_FREE_CHUNK==((*p2)->state_type)) {
      ((rsoc*)(*p2))->next=NULL;
      rsocfl=((rsoc*)(*p2));
    }
    else {
      rsocfl=NULL;
    }
  }
  while (p1 < eogcmt) {
    if (FREE_CHUNK((*p1)->state_type)) {
      if (RSO_FREE_CHUNK == ((*p1)->state_type)) {
	if (RSO_FREE_CHUNK == ((*p2)->state_type)) {
	  if (((char*)(*p2))+(*p2)->size == ((char*)(*p1))) {
	    ((*p2)->size)+=((*p1)->size);
	    p1++;
	  }
	  else {
	    ((rsoc*)(*p1))->next=rsocfl;
	    rsocfl=((rsoc*)(*p1));
	    *(p2+1)=*p1; p2++; p1++;
	  }
	}
	else {
	  ((rsoc*)(*p1))->next=rsocfl;
	  rsocfl=((rsoc*)(*p1));
	  *(p2+1)=*p1; p2++; p1++;
	}
      }
      else {
	*(p2+1)=*p1; p2++; p1++;
      }
    }
    else {
      ((*p1)->swfp)(*p1);
      if (RSO_FREE_CHUNK == ((*p1)->state_type)) {
	if (RSO_FREE_CHUNK == ((*p2)->state_type)) {
	  if (((char*)(*p2))+(*p2)->size == ((char*)(*p1))) {
	    ((*p2)->size)+=((*p1)->size);
	    p1++;
	  }
	  else {
	    ((rsoc*)(*p1))->next=rsocfl;
	    rsocfl=((rsoc*)(*p1));
	    *(p2+1)=*p1; p2++; p1++;
	  }
	}
	else {
	  ((rsoc*)(*p1))->next=rsocfl;
	  rsocfl=((rsoc*)(*p1));
	  *(p2+1)=*p1; p2++; p1++;
	}
      }
      else {
	*(p2+1)=*p1; p2++; p1++;
      }
    }
  }
  gcmt_used=(p2-gcmt)+1;
}

void gc_mark(void*p) {
  if ((p>((void*)*gcmt))&&(p<=gcmt_tail_addr)) {
    int i1=0;
    int i2=gcmt_used-1;
    int m=i2>>1;
    mch*c;
    for (;i2>i1;m=((i1+i2)>>1)) {
      if (p<=((void*)gcmt[m+1])) {
	i2=m;
      }
      else {
	i1=m+1;
      }
    }
    c=gcmt[i2];
    if (!(FREE_CHUNK(c->state_type))) {
      (c->amfp)(c,p);
    }
  }
}

int gc_stack_size(void) {
  void*stack_top[2]={NULL,NULL};
  if (stack_top > stack_bottom) {
    return ((void**)stack_top)-((void**)stack_bottom);
  }
  else {
    return ((void**)stack_bottom)-((void**)stack_top);
  }
}

/*
  To delay Garbage Collection when the stack is too large.
  To allow fast increase of ceils.
*/
#define FSOC_LIMIT (10240/((FSOC_SIZE)>>10))
#define RSOC_LIMIT (10240/((RSOC_SIZE)>>10))

/*
  When stack is too large, collection may be delayed.
*/
#define GCLARGESTACK 50000

int garbage_delayed(void) {
  /*
    To delay the first GC call.
  */
  if (gc_stack_size() > GCLARGESTACK) {
    if (fsoc_count_ceil <= fsoc_count) {
      if (rsoc_count_ceil <= rsoc_count) {
	if ((fsoc_count<FSOC_LIMIT)&&(rsoc_count<RSOC_LIMIT)) {
	  fsoc_count_ceil++;
	  rsoc_count_ceil++;
	  return 1;
	}
	else return 0;
      }
      else {
	if (fsoc_count<FSOC_LIMIT) {
	  fsoc_count_ceil++;
	  return 1;
	}
	else return 0;
      }
    }
    else {
      if (rsoc_count_ceil <= rsoc_count) {
	if (rsoc_count<RSOC_LIMIT) {
	  rsoc_count_ceil++;
	  return 1;
	}
	else return 0;
      }
      else return 0;
    }
  }
  else {
    return 0;
  }
}

void gc_update_ceils(void) {
  int c;

  /* Compute fsoc_count_ceil :
   */
  if (fsocfl==NULL) {
    if (fsoc_count >= fsoc_count_ceil) {
      if (fsoc_count_ceil<FSOC_LIMIT) {
	fsoc_count_ceil<<=1;
      }
      else {
	c=fsoc_count+(fsoc_count/3);
	if (fsoc_count_ceil < c)
	  fsoc_count_ceil=c;
      }
    }
  }
  else
    if (fsoc_count_ceil < fsoc_count)
      fsoc_count_ceil=fsoc_count;
  /* Compute rsoc_count_ceil :
   */
  if (rsocfl==NULL) {
    if (rsoc_count>=rsoc_count_ceil) {
      if (rsoc_count_ceil<RSOC_LIMIT) {
	rsoc_count_ceil<<=1;
      }
      else {
	c=rsoc_count+(rsoc_count/3);
	if (rsoc_count_ceil < c)
	  rsoc_count_ceil=c;
      }
    }
  }
  else
    if (rsoc_count_ceil < rsoc_count)
      rsoc_count_ceil=rsoc_count;
}

static void add_to_gcmt(mch*c) {
  mch**p;
  if (gcmt_used==gcmt_max) {
    gcmt_max<<=1;
    gcmt=((mch**)(realloc(gcmt,(gcmt_max+1)*sizeof(void*))));
  }
  for(p=gcmt+(gcmt_used++ -1);(p>=gcmt)&&(*p>c);p--)
    *(p+1)=*p;
  *(p+1)=c;
}

fsoc*new_fsoc(void) {
  if (fsocfl != NULL) {
    fsoc*r=fsocfl;
    fsocfl=fsocfl->next;
    return r;
  }
  else {
    mch*r=((mch*)(se_malloc(FSOC_SIZE)));
    mch**p;
    gc_update_ceils();
    fsoc_count++;
    if (gcmt_used==gcmt_max) {
      gcmt_max<<=1;
      gcmt=((mch**)(realloc(gcmt,(gcmt_max+1)*sizeof(void*))));
    }
    for (p=gcmt+(gcmt_used++ -1);(p>=gcmt)&&(*p>r);p--)
      *(p+1)=*p;
    *(p+1)=r;
    return (fsoc*)r;
  }
}

static char*rso_from_store(na_env*nae,int size) {
  rsoh*r=(nae->store);
  nae->store_left-=size;
  if ((nae->store_left) > sizeof(rsoh)) {
    r->header.size=size;
    nae->store=((rsoh*)(((char*)(nae->store))+size));
  }
  else {
    r->header.size=size+nae->store_left;
    nae->store_left=0;
  }
  (r->header.magic_flag)=RSOH_UNMARKED;
  ((void)memset((r+1),0,r->header.size-sizeof(rsoh)));
  return (char*)(r+1);
}

static void rsoc_sweep(rsoc*c) {
  na_env*nae=c->nae;
  rsoh*gp=(rsoh*)&(c->first_header);
  rsoh*pp;
  rsoh*eoc=((rsoh*)(((char*)c)+c->header.size));
  c->free_list_of_large=NULL;
  if (c->header.size > RSOC_SIZE) {
    if (gp->header.magic_flag == RSOH_MARKED) {
      gp->header.magic_flag=RSOH_UNMARKED;
      c->next=nae->chunk_list;
      nae->chunk_list=c;
    }
    else {
      c->header.state_type=RSO_FREE_CHUNK;
    }
    return;
  }
  while (gp<eoc) {
    while (gp->header.magic_flag == RSOH_MARKED) {
      gp->header.magic_flag=RSOH_UNMARKED;
      gp=((rsoh*)(((char*)gp)+gp->header.size));
      if(gp>=eoc) {
	c->next=nae->chunk_list;
	nae->chunk_list=c;
	return;
      }
    }
    gp->header.magic_flag=RSOH_FREE;
    pp=(rsoh*)(((char*)gp)+gp->header.size);
    while ((pp<eoc)&&(pp->header.magic_flag != RSOH_MARKED)) {
      pp->header.magic_flag=RSOH_FREE;
      gp->header.size+=pp->header.size;
      pp=((rsoh*)(((char*)pp)+pp->header.size));
    }
    if (gp->header.size >= RSOC_MIN_STORE) {
      if (nae->store_left==0) {
	nae->store_left=gp->header.size;
	nae->store=gp;
	nae->store_chunk=c;
      }
      else if (nae->store->header.size < gp->header.size) {
	((fll_rsoh*)nae->store)->nextflol=nae->store_chunk->free_list_of_large;
	nae->store_chunk->free_list_of_large=((fll_rsoh*)nae->store);
	nae->store_left=gp->header.size;
	nae->store=gp;
	nae->store_chunk=c;
      }
      else {
	((fll_rsoh*)gp)->nextflol=c->free_list_of_large;
	c->free_list_of_large=((fll_rsoh*)gp);
      }
    }
    gp=pp;
  }
  if (((rsoh*)(&c->first_header))->header.size >=
      (c->header.size-sizeof(rsoc)+sizeof(rsoh))){
    c->header.state_type=RSO_FREE_CHUNK;
    nae->store_chunk=NULL;
    nae->store_left=0;
  }
  else{
    c->next=nae->chunk_list;
    nae->chunk_list=c;
  }
}

static rsoc MRSOC = {
    {
	RSOC_SIZE,
	RSO_USED_CHUNK,
	((void(*)(mch*,void*))gcna_align_mark),
	((void(*)(mch*))rsoc_sweep)
    },
    NULL,
    NULL,
    NULL,
    {
      {
	0,
	RSOH_MARKED
      }
    }
};

static void rsoc_malloc(na_env*nae){
  rsoc*r=((rsoc*)(se_malloc(RSOC_SIZE)));
  rsoc_count++;
  *r=MRSOC;
  r->nae=nae;
  nae->store=(&(r->first_header));
  nae->store_left=RSOC_SIZE-sizeof(rsoc)+sizeof(rsoh);
  nae->store_chunk=r;
  r->next=nae->chunk_list;
  nae->chunk_list=r;
  add_to_gcmt((mch*)r);
}

static rsoc* rsocfl_best_fit(int size) {
  int best_size;
  rsoc *pc,*best_pc,*best_c, *c;
  if (rsocfl==NULL)
    return NULL;
  pc=NULL;
  best_pc=NULL;
  best_c=NULL;
  c=rsocfl;
  while ((NULL!=c)&&(NULL==best_c)){
    if (c->header.size>=size){
      best_c=c;
      best_pc=pc;
      best_size=c->header.size;
    }
    pc=c;
    c=c->next;
  }
  if (NULL==c){
    if (best_pc != NULL)
      best_pc->next=best_c->next;
    else if (best_c==rsocfl)
      rsocfl=best_c->next;
    return best_c;
  }
  do{
    if ((c->header.size>=size)&&(c->header.size<best_size)){
      best_c=c;
      best_pc=pc;
      best_size=c->header.size;
    }
    pc=c;
    c=c->next;
  } while(c!=NULL);
  if (NULL==best_pc) {
    rsocfl = best_c->next;
  }
  else {
    best_pc->next=best_c->next;
  }
  return best_c;
}

static int get_store_in(rsoc*c,int size) {
  na_env*nae=c->nae;
  fll_rsoh*pf=NULL;
  fll_rsoh*f=c->free_list_of_large;
  while (f != NULL) {
    if (f->rsoh_field.size >= size) {
      nae->store_left=f->rsoh_field.size;
      nae->store=(rsoh*)f;
      nae->store_chunk=c;
      if (pf == NULL) {
	c->free_list_of_large=f->nextflol;
      }
      else {
	pf->nextflol=f->nextflol;
      }
      return 1;
    }
    pf = f;
    f = f->nextflol;
  }
  return 0;
}

char*new_na_from_chunk_list(na_env*nae,int size) {
  rsoc*c=nae->chunk_list;
  int csize;
  while (c != NULL) {
    if (get_store_in(c,size)) {
      return rso_from_store(nae,size);
    }
    c = c->next;
  }
  csize=size+(sizeof(rsoc)-sizeof(rsoh));
  c=rsocfl_best_fit(csize);
  if (c != NULL){
    if ((c->header.size > RSOC_SIZE)
	&&
	(c->header.size-csize > RSOC_MIN_STORE*4)) {
      int csize_left=c->header.size-csize;
      if ((csize_left%sizeof(double))!=0) {
	csize_left-=(csize_left%sizeof(double));
	csize=c->header.size-csize_left;
      }
      c->header.size=csize_left;
      c->next=rsocfl;
      rsocfl=c;
      c=(rsoc*)(((char*)c)+csize_left);
      add_to_gcmt((mch*)c);
      c->header.amfp=(void(*)(mch*,void*))gcna_align_mark;
      c->header.swfp=(void(*)(mch*))rsoc_sweep;
    }
    else {
      csize=c->header.size;
    }
    c->header.size=csize;
    c->header.state_type=RSO_USED_CHUNK;
    c->free_list_of_large=NULL;
    c->nae=nae;
    nae->store=(&(c->first_header));
    nae->store_left=csize-sizeof(rsoc)+sizeof(rsoh);
    nae->store_chunk=c;
    c->next=nae->chunk_list;
    nae->chunk_list=c;
    return rso_from_store(nae,size);
  }
  return NULL;
}

char*new_na(na_env*nae,int size) {
  if (nae->store_left>0) {
    nae->store->header.size=nae->store_left;
    nae->store->header.magic_flag=RSOH_FREE;
    if (nae->store_left >= RSOC_MIN_STORE) {
      ((fll_rsoh*)(nae->store))->nextflol=nae->store_chunk->free_list_of_large;
      nae->store_chunk->free_list_of_large=((fll_rsoh*)nae->store);
    }
    nae->store_left=0;
  }
  if ((nae->store_chunk!=NULL)&&(get_store_in(nae->store_chunk,size))) {
    return rso_from_store(nae,size);
  }
  {
    char*r=new_na_from_chunk_list(nae,size);
    if (r!=NULL)
      return r;
  }
  if (rsoc_count<rsoc_count_ceil) {
    if((size+sizeof(rsoc)-sizeof(rsoh))>RSOC_SIZE){
      rsoc*c=((rsoc*)(se_malloc(size+sizeof(rsoc)-sizeof(rsoh))));
      rsoh*r=(&(c->first_header));
      rsoc_count++;
      *c=MRSOC;
      c->header.size=size+sizeof(rsoc)-sizeof(rsoh);
      c->nae=nae;
      c->next=nae->chunk_list;
      nae->chunk_list=c;
      add_to_gcmt((mch*)c);
      r->header.size=size;
      (r->header.magic_flag)=RSOH_UNMARKED;
      ((void)memset((r+1),0,size-sizeof(rsoh)));
      return (char*)(r+1);
    }
    else {
      rsoc_malloc(nae);
      return rso_from_store(nae,size);
    }
  }
  gc_start();
  if (size<=(nae->store_left)) {
    return rso_from_store(nae,size);
  }
  {
    char*r=new_na_from_chunk_list(nae,size);
    if (r!=NULL) {
      return r;
    }
  }
  if((size+sizeof(rsoc)-sizeof(rsoh))>RSOC_SIZE){
    rsoc*c=((rsoc*)(se_malloc(size+sizeof(rsoc)-sizeof(rsoh))));
    rsoh*r=(&(c->first_header));
    rsoc_count++;
    *c=MRSOC;
    c->header.size=size+sizeof(rsoc)-sizeof(rsoh);
    c->nae=nae;
    c->next=nae->chunk_list;
    nae->chunk_list=c;
    add_to_gcmt((mch*)c);
    r->header.size=size;
    (r->header.magic_flag)=RSOH_UNMARKED;
    ((void)memset((r+1),0,size-sizeof(rsoh)));
    gc_update_ceils();
    return (char*)(r+1);
  }
  else {
    rsoc_malloc(nae);
    gc_update_ceils();
    return rso_from_store(nae,size);
  }
}

void gcna_align_mark(rsoc*c,void*o) {
  na_env* nae = c->nae;
  fll_rsoh* f;
  fll_rsoh* pf;
  char* b = (char*)&(c->first_header);
  if (((char*)o) > (((char*)c)+c->header.size)) {
      return;
  }
  if (((((char*)o)-((char*)c))%sizeof(int)) != 0) {
      return;
  }
  if ((((rsoh*)o)-1)->header.magic_flag != RSOH_UNMARKED) {
      return;
  }
  if (((char*)o) < ((char*)(c+1))) {
      return;
  }
  if (c->header.size > RSOC_SIZE) {
      if (o == (c+1)) {
	  nae->gc_mark((T0*)o);
      }
      return;
  }
  pf=NULL;
  f=c->free_list_of_large;
  while ((f != NULL) && (f < ((fll_rsoh*)o))) {
      pf=f;
      f=f->nextflol;
  }
  if (pf == NULL) {
      pf=(fll_rsoh*)b;
  }
  while ((((rsoh*)pf)+1) < (rsoh*)o) {
      pf = ((fll_rsoh*)(((char*)pf)+pf->rsoh_field.size));
  }
  {void* tmp = (((rsoh*)pf)+1);
  if (o == tmp) {
      nae->gc_mark((T0*)o);
  }
  }
}

int rsocfl_count(void) {
  int r=0;
  rsoc*p=rsocfl;
  while (p!=NULL) {
    r++;
    p=p->next;
  }
  return r;
}

int fsocfl_count(void) {
  int r=0;
  fsoc*p=fsocfl;
  while (p!=NULL) {
    r++;
    p=p->next;
  }
  return r;
}

void rsocfl_info(void) {
  int max=0;
  rsoc*p=rsocfl;
  fprintf(SE_GCINFO," rsocfl count = %d\n",rsocfl_count());
  if (p!=NULL) {
    fprintf(SE_GCINFO," rsocfl = [");
    p=rsocfl;
    while (p!=NULL) {
      fprintf(SE_GCINFO,"%d",p->header.size);
      if(max < p->header.size) max=p->header.size;
      p=p->next;
      if (p!=NULL)fprintf(SE_GCINFO,",");
    }
    fprintf(SE_GCINFO,"]\n");
    fprintf(SE_GCINFO," rsocfl max = %d\n",max);
  }
}

void gc_dispose_before_exit(void) {
  mch** p = gcmt;
  mch**eogcmt=gcmt+gcmt_used;

  while (p < eogcmt) {
    if (((*p)->state_type == FSO_STORE_CHUNK) ||
	((*p)->state_type == FSO_USED_CHUNK)) {
      ((*p)->swfp)(*p);
    }
    p++;
  }
}

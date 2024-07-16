/*
  SPDX-License-Identifier: Apache-2.0
*/

import {Object, Property} from 'fabric-contract-api';

@Object()
export class PemetaanHutan {
    @Property()
    public idHutan: string;
 
    @Property()
    public namaHutan: string;

    @Property()
    public longitude: string;

    @Property()
    public latitude: string;
    
    @Property()
    public created_at: string;

    @Property()
    public updated_at: string;
}